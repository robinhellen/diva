using Gee;

namespace Diva
{
    internal class CreatorIndex<TService, TKey>: Object, Index<TService, TKey>
    {
        public CreatorIndex(Map<TKey, ICreator<TService>> keyedCreators, ComponentContext context)
        {
            this.context = context;
            this.keyedCreators = keyedCreators;
        }

        private Map<TKey, ICreator<TService>> keyedCreators {set; get;}
        public ComponentContext context {construct set; private get;}

        public new TService @get(TKey key)
        {
            var creator = keyedCreators[key];
            if(creator == null)
                return null;
            return creator.create(context);
        }
    }

    internal class CreatorTypedIndex<TService, TKey>: Object, Index<TService, TKey>
    {
        private Map<TKey, ICreator<TService>> keyedCreators {set; get;}
        public ComponentContext context {construct set; private get;}
        public Map<Value?, ICreator> keysForService {construct; private get;}

        construct
        {
            var t = typeof(TService);
            var tkey = typeof(TKey);
            if(tkey == typeof(string))
            {
                keyedCreators = new HashMap<TKey, ICreator<TService>>(x => str_hash((string) x), (x, y) => str_equal((string)x, (string)y));
            }
            else
            {
                keyedCreators = new HashMap<TKey, ICreator<TService>>();
            }

            foreach(var v in keysForService.entries)
            {
                if(v.key.type() != tkey)
                    continue;
                keyedCreators[ExtractKey<TKey>(v.key)] = v.value;
            }
        }

        public new TService @get(TKey key)
        {
            var creator = keyedCreators[key];
            if(creator == null)
                return null;
            return creator.create(context);
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


