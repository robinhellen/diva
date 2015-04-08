using Gee;

namespace Diva
{
	public void SetLazyInjection<TDependency>(ObjectClass cls, string property)
	{
		var pspec = cls.find_property(property);
        
		if(pspec == null) assert_not_reached();
		if(pspec.value_type != typeof(Lazy)) assert_not_reached();

		var depType = typeof(TDependency); // apparently, if I inline this then it becomes G_TYPE_INVALID
		
		var data = (LazyPropertyData)Object.new(typeof(LazyPropertyData), DepType: depType);
		LazyPropertyData.refs.add(data); // need to store a reference somewhere as the qdata doesn't hold the reference!
		pspec.set_qdata(LazyPropertyData.Q, data);
	}
    
    internal class LazyPropertyData : Object
    {
        public Type DepType {get; construct;}
        
		public static Collection<LazyPropertyData> refs = new LinkedList<LazyPropertyData>();
        public static Quark Q = Quark.from_string("diva.lazy");
    }
}

