using Gee;

namespace Diva
{
    internal class DefaultContainer : IContainer, ComponentContext, Object
    {
        private Map<Type, ICreator> services;
        private Map<Type, Map<Value?, ICreator>> keyedServices;
        private MultiMap<Type, IDecoratorCreator> decorators;
        private MultiMap<Type, ICreator> allServices;

        private Deque<Type> currentCreations = new LinkedList<Type>();

        public DefaultContainer(Map<Type, ICreator> services,
                                MultiMap<Type, ICreator> allServices,
                                Map<Type, Map<Value?, ICreator>> keyedServices,
                                MultiMap<Type, IDecoratorCreator>? decorators
                                )
        {
            this.services = services;
            this.allServices = allServices;
            this.keyedServices = keyedServices;
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
            var keysForService = keyedServices[t];
            Map<TKey, ICreator> keyedCreators;
            if(tkey == typeof(string))
            {
                keyedCreators = new HashMap<TKey, ICreator<TService>>(x => str_hash((string) x), (x, y) => str_equal((string)x, (string)y));
            }
            else
            {
                keyedCreators = new HashMap<TKey, ICreator<TService>>();
            }

            foreach(var v in keysForService.entries)
            {
                if(v.key.type() != tkey)
                    continue;
                keyedCreators[ExtractKey<TKey>(v.key)] = v.value;
            }
            var index = new CreatorIndex<TService, TKey>(keyedCreators, this);
            return index;
        }

        private T ExtractKey<T>(Value v)
        {
            var valueType = v.type();
            if(valueType.is_enum())
            {
                var key = (T)v.get_enum();
                return key;
            }
            if(valueType == (typeof(string)))
            {
                var s = v.get_string();
                return s;
            }
            return (T)v.get_pointer;
        }

        internal Object resolve_typed(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;
            var o = realCreator.create(this);
            var decoratorCreators = decorators[t];
            if(decoratorCreators == null)
            {
                FinishedCreating(t);
                return o;
            }

            var decorated = o;
            foreach(var decoratorCreator in decoratorCreators)
            {
                IDecoratorCreator<Object> realDecoratorCreator = decoratorCreator;
                decorated = realDecoratorCreator.create_decorator(this, decorated);
            }
            FinishedCreating(t);
            return decorated;
        }

        internal Lazy resolve_lazy_typed(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;

            var o = realCreator.create_lazy(this);
            FinishedCreating(t);
            return o;
        }

        internal Collection resolve_collection_typed(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var collection = new LinkedList<Object>();
            var creators = allServices[t];
            foreach(var creator in creators)
            {
                ICreator<Object> realCreator = creator;

                var o = realCreator.create(this);
                collection.add(o);
            }
            FinishedCreating(t);
            return collection;
        }

        internal Index resolve_index_typed(Type tService, Type tKey)
            throws ResolveError
        {
            var keysForService = keyedServices[tService];

            var index = (CreatorTypedIndex)Object.new(typeof(CreatorTypedIndex),
                tkey_type: tKey,
                tservice_type: tService,
                context: this,
                keysForService: keysForService
            );
            return index;
        }

        private void CheckForLoop(Type t)
            throws ResolveError
        {
            if(currentCreations.contains(t))
                throw new ResolveError.CyclicDependencies("Whee!! - I'm in a loop.");

            currentCreations.offer_head(t);
        }

        private void FinishedCreating(Type t)
        {
            var head = currentCreations.poll_head();
            if(head != t)
                assert_not_reached();
        }
    }
}
