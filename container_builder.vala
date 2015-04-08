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
            foreach(var registration in registrations)
            {
                var creator = registration.GetCreator();
                services[registration.Type] = creator;
                foreach(var service in registration.services)
                {
                    services[service] = creator;
                }
            }

            return new DefaultContainer(services);
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
        private Collection<Type> _services = new LinkedList<Type>();
        internal CreationStrategy creation_strategy {get; set;}

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolveFunc = (owned) resolver;
        }

        internal Collection<Type> services {get{return _services;}}

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

        public DefaultContainer(Map<Type, ICreator> services)
        {
            this.services = services;
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
