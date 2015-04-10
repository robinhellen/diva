using Gee;

namespace Diva
{
	public interface Index<TDependency, TKey> : Object
	{
		public abstract TDependency @get(TKey key);
	}

	public void SetIndexedInjection<TKey, TDependency>(ObjectClass cls, string property)
	{
		var pspec = cls.find_property(property);
		if(pspec == null) assert_not_reached();
		if(pspec.value_type != typeof(Index)) assert_not_reached();

		var keyType = typeof(TKey); // apparently, if I inline this then it becomes G_TYPE_INVALID
		var depType = typeof(TDependency);

		var data = (IndexPropertyData)Object.new(typeof(IndexPropertyData), Key: keyType, Dependency: depType);
		IndexPropertyData.refs.add(data); // need to store a reference somewhere as the qdata doesn't hold the reference!
		pspec.set_qdata(IndexPropertyData.Q, data);
	}


	private class IndexPropertyData : Object
	{
        public static Quark Q = Quark.from_string("diva.indexed");
        
		public Type Key {get; construct;}
		public Type Dependency {get; construct;}

		public static Collection<IndexPropertyData> refs = new LinkedList<IndexPropertyData>();
	}
}

