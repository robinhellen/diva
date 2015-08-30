using Gee;

namespace Diva
{
    private class InstanceRegistrationContext<T> : Object, IRegistrationContext<T>
    {
        private Collection<ServiceRegistration> _services = new LinkedList<ServiceRegistration>();
        private Collection<Type> _decorations = new LinkedList<Type>();

        internal Collection<ServiceRegistration> services {get{return _services;}}
        internal Collection<Type> decorations {get{return _decorations;}}
        internal CreationStrategy creation_strategy {get; set;}

        private T instance;

        public InstanceRegistrationContext(T instance)
        {
            this.instance = instance;
        }

        public ICreator get_creator()
        {
            return new InstanceCreator<T>(instance);
        }

        public IDecoratorCreator get_decorator_creator()
        {
            assert_not_reached();
        }

        public IRegistrationContext<T> ignore_property(string property)
        {
            return this;
        }

        private class InstanceCreator<T> : Object, ICreator<T>
        {
            private T instance;

            public InstanceCreator(T instance)
            {
                this.instance = instance;
            }

            public T create(ComponentContext context)
                throws ResolveError
            {
                return instance;
            }

            public Lazy<T> create_lazy(ComponentContext context)
                throws ResolveError
            {
                return new Lazy<T>.from_value(instance);
            }
        }
    }
}
