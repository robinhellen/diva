using Gee;

namespace Diva
{
    public void set_collection_injection<TDependency>(ObjectClass cls, string property)
    {
        var pspec = cls.find_property(property);

        if(pspec == null) assert_not_reached();
        if(pspec.value_type != typeof(Collection)) assert_not_reached();

        var dep_type = typeof(TDependency); // apparently, if I inline this then it becomes G_TYPE_INVALID

        var data = (CollectionPropertyData)Object.new(typeof(CollectionPropertyData), dep_type: dep_type);
        CollectionPropertyData.refs.add(data); // need to store a reference somewhere as the qdata doesn't hold the reference!
        pspec.set_qdata(CollectionPropertyData.q, data);
    }

    internal class CollectionPropertyData : Object
    {
        public Type dep_type {get; construct;}

        public static Collection<CollectionPropertyData> refs = new LinkedList<CollectionPropertyData>();
        public static Quark q = Quark.from_string("diva.collection");
    }
}


