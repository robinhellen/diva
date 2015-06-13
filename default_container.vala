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

        public T Resolve<T>()
            throws ResolveError
        {
            var t = typeof(T);
            return (T) ResolveTyped(t);
        }

        public Lazy<T> ResolveLazy<T>()
            throws ResolveError
        {
            var t = typeof(T);
            return (Lazy<T>) ResolveLazyTyped(t);
        }

        public Index<TService, TKey> ResolveIndexed<TService, TKey>()
        {
            var t = typeof(TService);
            var tkey = typeof(TKey);
            var keysForService = keyedServices[t];
            var keyedCreators = new HashMap<TKey, ICreator<TService>>();

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
            return (T)v.get_pointer;
        }

        internal Object ResolveTyped(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;
            var o = realCreator.Create(this);
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
                decorated = realDecoratorCreator.CreateDecorator(this, decorated);
            }
            FinishedCreating(t);
            return decorated;
        }

        internal Lazy ResolveLazyTyped(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var creator = services[t];
            if(creator == null)
                throw new ResolveError.UnknownService(@"No component has been registered providing the service $(t.name()).");
            ICreator<Object> realCreator = creator;

            var o = realCreator.CreateLazy(this);
            FinishedCreating(t);
            return o;
        }

        internal Collection ResolveCollectionTyped(Type t)
            throws ResolveError
        {
            CheckForLoop(t);
            var collection = new LinkedList<Object>();
            var creators = allServices[t];
            foreach(var creator in creators)
            {
                ICreator<Object> realCreator = creator;

                var o = realCreator.Create(this);
                collection.add(o);
            }
            FinishedCreating(t);
            return collection;
        }

        internal Index ResolveIndexTyped(Type tService, Type tKey)
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
