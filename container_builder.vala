using Gee;

namespace Diva
{
    public class ContainerBuilder : Object
    {
        private Gee.List<IRegistrationContext> registrations = new LinkedList<IRegistrationContext>();

        public IRegistrationContext<T> Register<T>(owned ResolveFunc<T> resolver)
        {
            var registration = new DelegateRegistrationContext<T>(resolver);
            registrations.add(registration);
            return registration;
        }

        public IContainer Build()
        {
            return new DefaultContainer();
        }
    }

    public delegate T ResolveFunc<T>(ComponentContext context);

    public interface ComponentContext : Object {}

    public interface IContainer : Object
    {
        public abstract T Resolve<T>();
    }

    public class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        public DelegateRegistrationContext(ResolveFunc<T> resolver)
        {

        }
    }

    public class DefaultContainer : IContainer, Object
    {
        public T Resolve<T>()
        {
            return null;
        }
    }
}
