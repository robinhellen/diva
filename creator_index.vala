using Gee;

namespace Diva
{
    public class CreatorIndex<TService, TKey>: Object, Index<TService, TKey>
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
			return creator.Create(context);
		}
    }
    
    public class CreatorTypedIndex<TService, TKey>: Object, Index<TService, TKey>
    {        
		private Map<TKey, ICreator<TService>> keyedCreators {set; get;}
		public ComponentContext context {construct set; private get;}
        public Map<Value?, ICreator> keysForService {construct; private get;}
        
        construct
        {           
            var t = typeof(TService);
            var tkey = typeof(TKey);
            keyedCreators = new HashMap<TKey, ICreator<TService>>();
            
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
			return creator.Create(context);
		}
        
		private T ExtractKey<T>(Value v)
		{
			var valueType = v.type();
			if(valueType.is_enum())
			{
				var key = (T)v.get_enum();
				return key;
			}
			return (T)v.get_pointer;
		}
    }
}


