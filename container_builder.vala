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

        public IRegistrationContext<T> RegisterInstance<T>(T instance)
        {
            var registration = new InstanceRegistrationContext<T>(instance);
            registrations.add(registration);
            return registration;
        }

        public void RegisterModule<T>(T module = null)
            requires(typeof(T).is_a(typeof(Module)))
        {
            var realModule = module as Module;
            if(realModule == null)
                realModule = (Module)Object.new(typeof(T));

            realModule.Load(this);
        }

        public IContainer Build()
        {
            var services = new HashMap<Type, ICreator>();
            var allServices = new HashMultiMap<Type, ICreator>();
            var keyedServices = new HashMap<Type, Map<Value?, ICreator>>();
            var decorators = new HashMultiMap<Type, IDecoratorCreator>();
            foreach(var registration in registrations)
            {
                var creator = registration.get_creator();
                services[registration.component_type] = creator;
                foreach(var service in registration.services)
                {
                    services[service.service_type] = creator;
                    allServices[service.service_type] = creator;
                    if(service.keys != null)
                    foreach(var key in service.keys)
                    {
                        var s = keyedServices[service.service_type];
                        if(s == null)
                        {
                            s = new HashMap<Value?, ICreator>();
                            keyedServices[service.service_type] = s;
                        }
                        s[key] = creator;
                    }
                }
                foreach(var decoration in registration.decorations)
                {
                    decorators[decoration] = registration.get_decorator_creator();
                }
            }

            return new DefaultContainer(services, allServices, keyedServices, decorators);
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

        internal abstract Collection ResolveCollectionTyped(Type t)
            throws ResolveError;
    }

    public interface IContainer : Object
    {
        public abstract T Resolve<T>()
            throws ResolveError;

        public abstract Lazy<T> ResolveLazy<T>()
            throws ResolveError;
        public abstract Collection<T> ResolveCollection<T>()
            throws ResolveError;

        public abstract Index<TService, TKey> ResolveIndexed<TService, TKey>()
            throws ResolveError;
    }

    internal interface ICreator<T> : Object
    {
        public abstract T Create(ComponentContext context)
            throws ResolveError;

        public abstract Lazy<T> CreateLazy(ComponentContext context)
            throws ResolveError;
    }

    internal interface IDecoratorCreator<T> : Object
    {
        public abstract T CreateDecorator(ComponentContext context, T inner)
            throws ResolveError;

        /*public abstract Lazy<T> CreateLazy(ComponentContext context, Lazy<T> inner)
            throws ResolveError; */
    }

    public abstract class Module : Object
    {
        public abstract void Load(ContainerBuilder builder);
    }
}
