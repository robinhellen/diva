using Gee;

namespace Diva
{
    internal class AutoTypeRegistration<T> : Object, IRegistrationContext<T>
    {
        private Collection<Type> _services = new LinkedList<Type>();

        internal Collection<Type> services {get{return _services;}}

        public ICreator<T> GetCreator()
        {
            return new AutoTypeCreator<T>(this);
        }

        private class AutoTypeCreator<T> : Object, ICreator<T>
        {
            private AutoTypeRegistration<T> registration;

            public AutoTypeCreator(AutoTypeRegistration<T> registration)
            {
                this.registration = registration;
            }

            public T Create(ComponentContext context)
                throws ResolveError
            {
                var cls = typeof(T).class_ref();
                var properties = ((ObjectClass)cls).list_properties();
                var params = new Parameter[] {};
                foreach(var prop in properties)
                {
                    if(CanInjectProperty(prop))
                    {
                        var p = Parameter();
                        var t = prop.value_type;
                        p.name = prop.name;

                        p.value = Value(t);
                        try
                        {
                            p.value.set_object(context.ResolveTyped(t));
                        }
                        catch(ResolveError e)
                        {
                            throw new ResolveError.InnerError(@"Cannot satify parameter $(prop.name) [$(t.name())]: $(e.message)");
                        }

                        params += p;

                    }
                }
                return (T) Object.newv(typeof(T), params);
            }

            private bool CanInjectProperty(ParamSpec p)
            {
                var flags = p.flags;
                return (  ((flags & ParamFlags.CONSTRUCT) == ParamFlags.CONSTRUCT)
                  || ((flags & ParamFlags.CONSTRUCT_ONLY) == ParamFlags.CONSTRUCT_ONLY));
            }
        }
    }
}
