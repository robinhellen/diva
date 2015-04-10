using Gee;

namespace Diva
{
    public class ContainerBuilder : Object
    {
        private Gee.List<IRegistrationContext> registrations = new LinkedList<IRegistrationContext>();

        public IRegistrationContext<T> Register<T>(owned ResolveFunc<T>? resolver = null)
        {
            if(resolver == null)
            {
                var registration = new AutoTypeRegistration<T>();
                registrations.add(registration);
                return registration;
            }

            var registration = new DelegateRegistrationContext<T>((owned) resolver);
            registrations.add(registration);
            return registration;
        }

        public IContainer Build()
        {
            var services = new HashMap<Type, ICreator>();
            var keyedServices = new HashMap<Type, Map<Value?, ICreator>>();
            foreach(var registration in registrations)
            {
                var creator = registration.GetCreator();
                services[registration.Type] = creator;
                foreach(var service in registration.services)
                {
                    services[service.ServiceType] = creator;
                    if(service.Keys != null)
                    foreach(var key in service.Keys)
                    {
                        var s = keyedServices[service.ServiceType];
                        if(s == null)
                        {
                            s = new HashMap<Value?, ICreator>();
                            keyedServices[service.ServiceType] = s;
                        }
                        s[key] = creator;
                    }
                }
            }

            return new DefaultContainer(services, keyedServices);
        }
    }

    public delegate T ResolveFunc<T>(ComponentContext context)
            throws ResolveError;

    public interface ComponentContext : Object
    {
        internal abstract Object ResolveTyped(Type t)
            throws ResolveError;
            
        internal abstract Lazy ResolveLazyTyped(Type t)
            throws ResolveError;
    }

    public interface IContainer : Object
    {
        public abstract T Resolve<T>()
            throws ResolveError;
            
        public abstract Lazy<T> ResolveLazy<T>()
            throws ResolveError;
            
        public abstract Index<TService, TKey> ResolveIndexed<TService, TKey>()
            throws ResolveError;
    }

    public interface ICreator<T> : Object
    {
        public abstract T Create(ComponentContext context)
            throws ResolveError;
            
        public abstract Lazy<T> CreateLazy(ComponentContext context)
            throws ResolveError;
    }

    internal class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        private ResolveFunc<T> resolveFunc;
        private Collection<ServiceRegistration> _services = new LinkedList<ServiceRegistration>();
        internal CreationStrategy creation_strategy {get; set;}

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolveFunc = (owned) resolver;
        }

        internal Collection<ServiceRegistration> services {get{return _services;}}

        public ICreator<T> GetCreator()
        {
            return creation_strategy.GetFinalCreator<T>(new DelegateCreator<T>(this));
        }

        private class DelegateCreator<T> : ICreator<T>, Object
        {
            private DelegateRegistrationContext<T> registration;

            public DelegateCreator(DelegateRegistrationContext<T> registration)
            {
                this.registration = registration;
            }

            public T Create(ComponentContext context)
                throws ResolveError
            {
                try
                {
                    return registration.resolveFunc(context);
                }
                catch(ResolveError e)
                {
                    throw new ResolveError.InnerError(@"Unable to create $(typeof(T).name()): $(e.message)");
                }
            }
            
            public Lazy<T> CreateLazy(ComponentContext context)
                throws ResolveError
            {
                return new Lazy<T>(() => {return Create(context);});
            }
        }
    }

    internal class DefaultContainer : IContainer, ComponentContext, Object
    {
        private Map<Type, ICreator> services;
        private Map<Type, Map<Value?, ICreator>> keyedServices;
        
        public DefaultContainer(Map<Type, ICreator> services, Map<Type, Map<Value?, ICreator>> keyedServices)
        {
            this.services = services;
            this.keyedServices = keyedServices;
        }

        public T Resolve<T>()
            throws ResolveError
        {
            var t = typeof(T);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<T> realCreator = creator;
            return realCreator.Create(this);
        }
        
        public Lazy<T> ResolveLazy<T>()
            throws ResolveError
        {
            var t = typeof(T);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<T> realCreator = creator;
            return realCreator.CreateLazy(this);
        }
        
        public Index<TService, TKey> ResolveIndexed<TService, TKey>()
        {
            var t = typeof(TService);
            var tkey = typeof(TKey);
            var keysForService = keyedServices[t];
            var keyedCreators = new HashMap<TKey, ICreator<TService>>();
            
            foreach(var v in keysForService.entries)
            {
                if(v.key.type() != tkey)
                    continue;
                keyedCreators[ExtractKey<TKey>(v.key)] = v.value;
            }
            return new CreatorIndex<TService, TKey>(keyedCreators, this);
        }
        
		private T ExtractKey<T>(Value v)
		{
			var valueType = v.type();
			if(valueType.is_enum())
			{
				var key = (T)v.get_enum();
				return key;
			}
			return (T)v.get_pointer;
		}

        internal Object ResolveTyped(Type t)
            throws ResolveError
        {
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;
            return realCreator.Create(this);
        }

        internal Lazy ResolveLazyTyped(Type t)
            throws ResolveError
        {
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;
            
            return realCreator.CreateLazy(this);
        }
    }
}
