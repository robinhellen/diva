using Gee;

namespace Diva
{
    internal class CreatorIndex<TService, TKey>: Object, Index<TService, TKey>
    {
        public CreatorIndex(Map<TKey, Lazy<TService>> keyedCreators)
        {
            this.keyedCreators = keyedCreators;
        }

        private Map<TKey, Lazy<TService>> keyedCreators {set; get;}

        public new TService @get(TKey key)
        {
            var creator = keyedCreators[key];
            if(creator == null)
                return null;
            return creator.value;
        }
    }

    internal class CreatorTypedIndex<TService, TKey>: Object, Index<TService, TKey>
    {
        private Map<TKey, Lazy<TService>> keyedCreators {set; get;}
        public Map<Value?, ICreator> keysForService {construct set; private get;}
        
        public void Initialize(ComponentContext context)
            throws ResolveError
        {
            var tkey = typeof(TKey);
            if(tkey == typeof(string))
            {
                keyedCreators = new HashMap<TKey, Lazy<TService>>(x => str_hash((string) x), (x, y) => str_equal((string)x, (string)y));
            }
            else
            {
                keyedCreators = new HashMap<TKey, Lazy<TService>>();
            }

            foreach(var v in keysForService.entries)
            {
                if(v.key.type() != tkey)
                    continue;
                keyedCreators[ExtractKey<TKey>(v.key)] = v.value.create_lazy(context);
            }
            keysForService = null;
        }

        public new TService @get(TKey key)
        {
            var creator = keyedCreators[key];
            if(creator == null)
                return null;
            return creator.value;
        }

        private T ExtractKey<T>(Value v)
        {
            var valueType = v.type();
            if(valueType.is_enum())
            {
                var key = (T)v.get_enum();
                return key;
            }
            if(valueType == (typeof(string)))
            {
                var s = v.get_string();
                return s;
            }
            return (T)v.get_pointer;
        }
    }
}


