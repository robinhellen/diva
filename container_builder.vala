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

    public delegate T ResolveFunc<T>(ComponentContext context);

    public interface ComponentContext : Object
    {
        internal abstract Object ResolveTyped(Type t);
    }

    public interface IContainer : Object
    {
        public abstract T Resolve<T>();
    }

    public interface ICreator<T> : Object
    {
        public abstract T Create(ComponentContext context);
    }

    internal class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        private ResolveFunc<T> resolveFunc;
        private Collection<Type> _services = new LinkedList<Type>();

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolveFunc = (owned) resolver;
        }

        internal Collection<Type> services {get{return _services;}}

        public ICreator<T> GetCreator()
        {
            return new DelegateCreator<T>(this);
        }

        private class DelegateCreator<T> : ICreator<T>, Object
        {
            private DelegateRegistrationContext<T> registration;

            public DelegateCreator(DelegateRegistrationContext<T> registration)
            {
                this.registration = registration;
            }

            public T Create(ComponentContext context)
            {
                return registration.resolveFunc(context);
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
        {
            var creator = services[typeof(T)];
            ICreator<T> realCreator = creator;
            return realCreator.Create(this);
        }

        internal Object ResolveTyped(Type t)
        {
            var creator = services[t];
            ICreator<Object> realCreator = creator;
            return realCreator.Create(this);
        }
    }
}
