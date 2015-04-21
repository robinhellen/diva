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
            
        internal abstract Index ResolveIndexTyped(Type tService, Type tKey)
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
}
