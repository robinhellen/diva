using Gee;

namespace Diva
{
    internal enum CreationStrategy
    {
        PerDependency,
        SingleInstance;

        public ICreator<T> GetFinalCreator<T>(ICreator<T> creator)
        {
            switch(this)
            {
                case PerDependency:
                    return creator;
                case SingleInstance:
                    return new CachingCreator<T>(creator);
                default:
                    assert_not_reached();
            }
        }
    }

    internal class CachingCreator<T> : Object, ICreator<T>
    {
        private T cachedValue;
        private bool has_value = false;
        private ICreator<T> inner;

        public CachingCreator(ICreator<T> inner)
        {
            this.inner = inner;
        }

        public T Create(ComponentContext context)
            throws ResolveError
        {
            if(!has_value)
            {
                cachedValue = inner.Create(context);
                has_value = true;
            }
            return cachedValue;
        }
        
        public Lazy<T> CreateLazy(ComponentContext context)
        {
            if(has_value)
                return new Lazy<T>.from_value(cachedValue);
            
            return new Lazy<T>(() => {return Create(context);});
        }
    }
}
