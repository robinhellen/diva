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

        public ICreator GetCreator()
        {
            return new InstanceCreator<T>(instance);
        }

        public IDecoratorCreator GetDecoratorCreator()
        {
            assert_not_reached();
        }

        public IRegistrationContext<T> IgnoreProperty(string property)
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

            public T Create(ComponentContext context)
                throws ResolveError
            {
                return instance;
            }

            public Lazy<T> CreateLazy(ComponentContext context)
                throws ResolveError
            {
                return new Lazy<T>.from_value(instance);
            }
        }
    }
}
