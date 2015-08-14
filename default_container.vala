using Gee;

namespace Diva
{
    internal class DefaultContainer : IContainer, ComponentContext, Object
    {
        private Map<Type, ICreator> services;
        private Map<Type, Map<Value?, ICreator>> keyed_services;
        private MultiMap<Type, ICreator> decorators;
        private MultiMap<Type, ICreator> all_services;

        private Deque<Type> current_creations = new LinkedList<Type>();

        public DefaultContainer(Map<Type, ICreator> services,
                                MultiMap<Type, ICreator> all_services,
                                Map<Type, Map<Value?, ICreator>> keyed_services,
                                MultiMap<Type, ICreator>? decorators
                                )
        {
            this.services = services;
            this.all_services = all_services;
            this.keyed_services = keyed_services;
            this.decorators = decorators;
        }

        public T resolve<T>()
            throws ResolveError
        {
            var t = typeof(T);
            return ((Lazy<T>) resolve_lazy_typed(t)).value;
        }

        public Lazy<T> resolve_lazy<T>()
            throws ResolveError
        {
            var t = typeof(T);
            return (Lazy<T>) resolve_lazy_typed(t);
        }

        public Collection<T> resolve_collection<T>()
            throws ResolveError
        {
            var t = typeof(T);
            return (Collection<T>) resolve_collection_typed(t);
        }

        public Index<TService, TKey> resolve_indexed<TService, TKey>()
        {
            var t = typeof(TService);
            var tkey = typeof(TKey);
            var keys_for_service = keyed_services[t];
            Map<TKey, ICreator> keyed_creators;
            if(tkey == typeof(string))
            {
                keyed_creators = new HashMap<TKey, ICreator<TService>>(x => str_hash((string) x), (x, y) => str_equal((string)x, (string)y));
            }
            else
            {
                keyed_creators = new HashMap<TKey, ICreator<TService>>();
            }

            foreach(var v in keys_for_service.entries)
            {
                if(v.key.type() != tkey)
                    continue;
                keyed_creators[extract_key<TKey>(v.key)] = v.value;
            }
            var index = new CreatorIndex<TService, TKey>(keyed_creators, this);
            return index;
        }

        private T extract_key<T>(Value v)
        {
            var value_type = v.type();
            if(value_type.is_enum())
            {
                var key = (T)v.get_enum();
                return key;
            }
            if(value_type == (typeof(string)))
            {
                var s = v.get_string();
                return s;
            }
            return (T)v.get_pointer;
        }

        internal Lazy resolve_lazy_typed(Type t)
            throws ResolveError
        {
            check_for_loop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> real_creator = creator;

            var o = real_creator.create_lazy(this);
            var decorator_creators = decorators[t];
            var decorated = o;
            
            foreach(var decorator_creator in decorator_creators)
            {
                var context = new DecoratingComponentContext(this, decorated, t);
                ICreator<Object> real_decorator_creator = decorator_creator;
                decorated = real_decorator_creator.create_lazy(context);
            }           
            
            finished_creating(t);
            return decorated;
        }

        internal Collection resolve_collection_typed(Type t)
            throws ResolveError
        {
            check_for_loop(t);
            var collection = new LinkedList<Object>();
            var creators = all_services[t];
            foreach(var creator in creators)
            {
                ICreator<Object> real_creator = creator;

                var o = real_creator.create(this);
                collection.add(o);
            }
            finished_creating(t);
            return collection;
        }

        internal Index resolve_index_typed(Type t_service, Type t_key)
            throws ResolveError
        {
            var keys_for_service = keyed_services[t_service];

            var index = (CreatorTypedIndex)Object.new(typeof(CreatorTypedIndex),
                tkey_type: t_key,
                tservice_type: t_service,
                context: this,
                keysForService: keys_for_service
            );
            return index;
        }

        private void check_for_loop(Type t)
            throws ResolveError
        {
            if(current_creations.contains(t))
                throw new ResolveError.CyclicDependencies("Whee!! - I'm in a loop.");

            current_creations.offer_head(t);
        }

        private void finished_creating(Type t)
        {
            var head = current_creations.poll_head();
            if(head != t)
                assert_not_reached();
        }
        
        private class DecoratingComponentContext : Object, ComponentContext
        {
            private ComponentContext inner_context;
            private Lazy decorated_object;
            private Type decorated_type;
            
            public DecoratingComponentContext(ComponentContext inner_context, Lazy decorated_object, Type decorated_type)
            {
                this.inner_context = inner_context;
                this.decorated_object = decorated_object;
                this.decorated_type = decorated_type;
            }

            public Lazy resolve_lazy_typed(Type t)
                throws ResolveError
            {
                if(t == decorated_type)
                    return decorated_object;
                return inner_context.resolve_lazy_typed(t);
            }

            public Index resolve_index_typed(Type t_service, Type t_key)
                throws ResolveError
            {
                return inner_context.resolve_index_typed(t_service, t_key);
            }

            public Collection resolve_collection_typed(Type t)
                throws ResolveError
            {
                return inner_context.resolve_collection_typed(t);
            }
        }
    }
}
