using Gee;

namespace Diva
{
    internal class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        private ResolveFunc<T> resolve_func;
        private Collection<ServiceRegistration> _services = new LinkedList<ServiceRegistration>();
        private Collection<Type> _decorations = new LinkedList<Type>();

        internal CreationStrategy creation_strategy {get; set;}

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolve_func = (owned) resolver;
        }

        internal Collection<ServiceRegistration> services {get{return _services;}}
        internal Collection<Type> decorations {get{return _decorations;}}

        public ICreator get_creator()
        {
            return creation_strategy.get_final_creator<T>(new DelegateCreator<T>(this));
        }

        public IDecoratorCreator get_decorator_creator()
        {
            return creation_strategy.get_final_decorator_creator<T>(new DelegateCreator<T>(this));
        }

        public IRegistrationContext<T> ignore_property(string property)
        {
            return this;
        }

        private class DelegateCreator<T> : ICreator<T>, IDecoratorCreator<T>, Object
        {
            private DelegateRegistrationContext<T> registration;

            public DelegateCreator(DelegateRegistrationContext<T> registration)
            {
                this.registration = registration;
            }

            public T create_decorator(ComponentContext context, T inner)
                throws ResolveError
            {
                return create(context);
            }

            public T create(ComponentContext context)
                throws ResolveError
            {
                try
                {
                    return registration.resolve_func(context);
                }
                catch(ResolveError e)
                {
                    throw new ResolveError.InnerError(@"Unable to create $(typeof(T).name()): $(e.message)");
                }
            }

            public Lazy<T> create_lazy(ComponentContext context)
                throws ResolveError
            {
                return new Lazy<T>(() => {return create(context);});
            }
        }
    }
}
