using Gee;

namespace Diva
{
    internal class AutoTypeRegistration<T> : Object, IRegistrationContext<T>
    {
        private Collection<ServiceRegistration> _services = new LinkedList<ServiceRegistration>();

        internal Collection<ServiceRegistration> services {get{return _services;}}
        internal CreationStrategy creation_strategy {get; set;}

        public ICreator<T> GetCreator()
        {
            return creation_strategy.GetFinalCreator<T>(new AutoTypeCreator<T>(this));
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
                            CreatorFunc func;
                            if(IsSpecial(t, out func))
                                func(prop, context, ref p);
                            else
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
            
            public Lazy<T> CreateLazy(ComponentContext context)
            {
                return new Lazy<T>(() => { return Create(context); });
            }

            private bool CanInjectProperty(ParamSpec p)
            {
                var flags = p.flags;
                return (  ((flags & ParamFlags.CONSTRUCT) == ParamFlags.CONSTRUCT)
                  || ((flags & ParamFlags.CONSTRUCT_ONLY) == ParamFlags.CONSTRUCT_ONLY));
            }
            
            private bool IsSpecial(Type t, out CreatorFunc func)
            {
                if(t == typeof(Lazy))
                {
                    func = LazyCreator;
                    return true;
                }
                if(t == typeof(Index))
                {
                    func = IndexCreator;
                    return true;
                }
                func = null;
                return false;
            }
            
            private delegate void CreatorFunc(ParamSpec p, ComponentContext context, ref Parameter param)
                throws ResolveError;
            
            private void LazyCreator(ParamSpec p, ComponentContext context, ref Parameter param)
                throws ResolveError
            {
                // get the type                
                var lazyData = (LazyPropertyData)p.get_qdata(LazyPropertyData.Q);
                if(lazyData == null)
                    throw new ResolveError.BadDeclaration("To support injection of lazy properties, call SetLazyInjection in your static construct block.");
                Type t = lazyData.DepType;
            
                
                param.value.set_instance(context.ResolveLazyTyped(t));
            }
            
            private void IndexCreator(ParamSpec p, ComponentContext context, ref Parameter param)
                throws ResolveError
            {
                var indexData = (IndexPropertyData)p.get_qdata(IndexPropertyData.Q);
                if(indexData == null)
                     throw new ResolveError.BadDeclaration("To support injection of index properties, call SetIndexedInjection in your static construct block.");
                
                param.value.set_instance(context.ResolveIndexTyped(indexData.Dependency, indexData.Key));
            }
        }
    }
}
