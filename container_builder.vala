using Gee;

namespace Diva
{
    public class ContainerBuilder : Object
    {
        private Gee.List<IRegistrationContext> registrations = new LinkedList<IRegistrationContext>();

        public IRegistrationContext<T> Register<T>(owned ResolveFunc<T> resolver)
        {
            var registration = new DelegateRegistrationContext<T>((owned) resolver);
            registrations.add(registration);
            return registration;
        }

        public IContainer Build()
        {
            var services = new HashMap<Type, ICreator>();
            foreach(var registration in registrations)
            {
                services[registration.Type] = registration.GetCreator();
            }

            return new DefaultContainer(services);
        }
    }

    public delegate T ResolveFunc<T>(ComponentContext context);

    public interface ComponentContext : Object {}

    public interface IContainer : Object
    {
        public abstract T Resolve<T>();
    }

    public interface ICreator<T> : Object
    {
        public abstract T Create(ComponentContext context);
    }

    public class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        private ResolveFunc<T> resolveFunc;

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolveFunc = (owned) resolver;
        }

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

    public class DefaultContainer : IContainer, ComponentContext, Object
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
    }
}
