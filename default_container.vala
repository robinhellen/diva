using Gee;

namespace Diva
{
    internal class DefaultContainer : IContainer, ComponentContext, Object
    {
        private Map<Type, ICreator> services;
        private Map<Type, Map<Value?, ICreator>> keyed_services;
        private MultiMap<Type, IDecoratorCreator> decorators;
        private MultiMap<Type, ICreator> all_services;

        private Deque<Type> current_creations = new LinkedList<Type>();

        public DefaultContainer(Map<Type, ICreator> services,
                                MultiMap<Type, ICreator> all_services,
                                Map<Type, Map<Value?, ICreator>> keyed_services,
                                MultiMap<Type, IDecoratorCreator>? decorators
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
            return (T) resolve_typed(t);
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

        internal Object resolve_typed(Type t)
            throws ResolveError
        {
            check_for_loop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> real_creator = creator;
            var o = real_creator.create(this);
            var decorator_creators = decorators[t];
            if(decorator_creators == null)
            {
                finished_creating(t);
                return o;
            }

            var decorated = o;
            foreach(var decorator_creator in decorator_creators)
            {
                IDecoratorCreator<Object> real_decorator_creator = decorator_creator;
                decorated = real_decorator_creator.create_decorator(this, decorated);
            }
            finished_creating(t);
            return decorated;
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
            finished_creating(t);
            return o;
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
    }
}
