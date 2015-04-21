using Gee;

namespace Diva
{
    internal class DelegateRegistrationContext<T> : IRegistrationContext<T>, Object
    {
        private ResolveFunc<T> resolveFunc;
        private Collection<ServiceRegistration> _services = new LinkedList<ServiceRegistration>();
        private Collection<Type> _decorations = new LinkedList<Type>();

        internal CreationStrategy creation_strategy {get; set;}

        public DelegateRegistrationContext(owned ResolveFunc<T> resolver)
        {
            resolveFunc = (owned) resolver;
        }

        internal Collection<ServiceRegistration> services {get{return _services;}}
        internal Collection<Type> decorations {get{return _decorations;}}

        public ICreator<T> GetCreator()
        {
            return creation_strategy.GetFinalCreator<T>(new DelegateCreator<T>(this));
        }
        
        public IRegistrationContext<T> IgnoreProperty(string property)
        {
            return this;
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
}
