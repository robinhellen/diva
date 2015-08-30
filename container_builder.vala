using Gee;

namespace Diva
{
    public class ContainerBuilder : Object
    {
        private Gee.List<IRegistrationContext> registrations = new LinkedList<IRegistrationContext>();

        public IRegistrationContext<T> register<T>(owned ResolveFunc<T>? resolver = null)
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

        public IRegistrationContext<T> register_instance<T>(T instance)
        {
            var registration = new InstanceRegistrationContext<T>(instance);
            registrations.add(registration);
            return registration;
        }

        public void register_module<T>(T module = null)
            requires(typeof(T).is_a(typeof(Module)))
        {
            var real_module = module as Module;
            if(real_module == null)
                real_module = (Module)Object.new(typeof(T));

            real_module.load(this);
        }

        public IContainer build()
        {
            var services = new HashMap<Type, ICreator>();
            var all_services = new HashMultiMap<Type, ICreator>();
            var keyed_services = new HashMap<Type, Map<Value?, ICreator>>();
            var decorators = new HashMultiMap<Type, IDecoratorCreator>();
            foreach(var registration in registrations)
            {
                var creator = registration.get_creator();
                services[registration.component_type] = creator;
                foreach(var service in registration.services)
                {
                    services[service.service_type] = creator;
                    all_services[service.service_type] = creator;
                    if(service.keys != null)
                    foreach(var key in service.keys)
                    {
                        var s = keyed_services[service.service_type];
                        if(s == null)
                        {
                            s = new HashMap<Value?, ICreator>();
                            keyed_services[service.service_type] = s;
                        }
                        s[key] = creator;
                    }
                }
                foreach(var decoration in registration.decorations)
                {
                    decorators[decoration] = registration.get_decorator_creator();
                }
            }

            return new DefaultContainer(services, all_services, keyed_services, decorators);
        }
    }

    public delegate T ResolveFunc<T>(ComponentContext context)
            throws ResolveError;

    public interface ComponentContext : Object
    {
        internal abstract Object resolve_typed(Type t)
            throws ResolveError;

        internal abstract Lazy resolve_lazy_typed(Type t)
            throws ResolveError;

        internal abstract Index resolve_index_typed(Type t_service, Type t_key)
            throws ResolveError;

        internal abstract Collection resolve_collection_typed(Type t)
            throws ResolveError;
    }

    public interface IContainer : Object
    {
        public abstract T resolve<T>()
            throws ResolveError;

        public abstract Lazy<T> resolve_lazy<T>()
            throws ResolveError;
        public abstract Collection<T> resolve_collection<T>()
            throws ResolveError;

        public abstract Index<TService, TKey> resolve_indexed<TService, TKey>()
            throws ResolveError;
    }

    internal interface ICreator<T> : Object
    {
        public abstract T create(ComponentContext context)
            throws ResolveError;

        public abstract Lazy<T> create_lazy(ComponentContext context)
            throws ResolveError;
    }

    internal interface IDecoratorCreator<T> : Object
    {
        public abstract T create_decorator(ComponentContext context, T inner)
            throws ResolveError;

        /*public abstract Lazy<T> CreateLazy(ComponentContext context, Lazy<T> inner)
            throws ResolveError; */
    }

    public abstract class Module : Object
    {
        public abstract void load(ContainerBuilder builder);
    }
}
