using Gee;

namespace Diva
{
    internal enum CreationStrategy
    {
        PER_DEPENDENCY,
        SINGLE_INSTANCE;

        public ICreator<T> get_final_creator<T>(ICreator<T> creator)
        {
            switch(this)
            {
                case PER_DEPENDENCY:
                    return creator;
                case SINGLE_INSTANCE:
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

        public T create(ComponentContext context)
            throws ResolveError
        {
            if(!has_value)
            {
                cachedValue = inner.create(context);
                has_value = true;
            }
            return cachedValue;
        }

        public Lazy<T> create_lazy(ComponentContext context)
        {
            if(has_value)
                return new Lazy<T>.from_value(cachedValue);

            return new Lazy<T>(() => {return create(context);});
        }
    }
}
