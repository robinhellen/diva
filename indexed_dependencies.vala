using Gee;

namespace Diva
{
    public interface Index<TDependency, TKey> : Object
    {
        public abstract TDependency @get(TKey key);
    }

    public void set_indexed_injection<TKey, TDependency>(ObjectClass cls, string property)
    {
        var pspec = cls.find_property(property);
        if(pspec == null) assert_not_reached();
        if(pspec.value_type != typeof(Index)) assert_not_reached();

        var key_type = typeof(TKey); // apparently, if I inline this then it becomes G_TYPE_INVALID
        var dep_type = typeof(TDependency);

        var data = (IndexPropertyData)Object.new(typeof(IndexPropertyData), key: key_type, dependency: dep_type);
        IndexPropertyData.refs.add(data); // need to store a reference somewhere as the qdata doesn't hold the reference!
        pspec.set_qdata(IndexPropertyData.q, data);
    }


    private class IndexPropertyData : Object
    {
        public static Quark q = Quark.from_string("diva.indexed");

        public Type key {get; construct;}
        public Type dependency {get; construct;}

        public static Collection<IndexPropertyData> refs = new LinkedList<IndexPropertyData>();
    }
}

