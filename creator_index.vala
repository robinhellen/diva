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

		/*public void Initialize(Map<Value?, Registration> registrations)
		{
			Makers = new HashMap<TKey, Maker>();
			foreach(var entry in registrations.entries)
			{
				var v = entry.key;

				Makers[ExtractKey(v)] = entry.value.Maker;
			}
		}

		private TKey ExtractKey(Value v)
		{
			var valueType = v.type();
			if(valueType.is_enum())
			{
				var key = (TKey)v.get_enum();
				return key;
			}
			return (TKey)v.get_pointer;
		}*/
    }
}


