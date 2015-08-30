using Gee;

namespace Diva
{
    public void set_lazy_injection<TDependency>(ObjectClass cls, string property)
    {
        var pspec = cls.find_property(property);

        if(pspec == null) assert_not_reached();
        if(pspec.value_type != typeof(Lazy)) assert_not_reached();

        var dep_type = typeof(TDependency); // apparently, if I inline this then it becomes G_TYPE_INVALID

        var data = (LazyPropertyData)Object.new(typeof(LazyPropertyData), dep_type: dep_type);
        LazyPropertyData.refs.add(data); // need to store a reference somewhere as the qdata doesn't hold the reference!
        pspec.set_qdata(LazyPropertyData.q, data);
    }

    internal class LazyPropertyData : Object
    {
        public Type dep_type {get; construct;}

        public static Collection<LazyPropertyData> refs = new LinkedList<LazyPropertyData>();
        public static Quark q = Quark.from_string("diva.lazy");
    }
}

