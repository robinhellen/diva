 using Gee;

namespace Diva
{
    [GenericAccessors]
    public interface IRegistrationContext<T> : Object
    {
        internal abstract ICreator get_creator();
        internal abstract IDecoratorCreator get_decorator_creator();

        public Type component_type {get {return typeof(T);}}

        internal abstract Collection<ServiceRegistration> services {get;}
        internal abstract Collection<Type> decorations {get;}
        internal abstract CreationStrategy creation_strategy {get; set;}

        public IRegistrationContext<T> as<TInterface>()
            requires(typeof(T).is_a(typeof(TInterface)))
        {
            add_service_registration(typeof(TInterface));
            return this;
        }

        public IRegistrationContext<T> single_instance()
        {
            creation_strategy = CreationStrategy.SINGLE_INSTANCE;
            return this;
        }

        public IRegistrationContext<T> keyed<TService, TKey>(TKey key)
            requires(typeof(T).is_a(typeof(TService)))
        {
            var t = typeof(TKey);
            var key_value = Value(t);
            if(t.is_object())
                key_value.set_object((Object)key);
            if(t.is_enum())
                key_value.set_enum((int) key);
            if(t == typeof(string))
                key_value.set_string((string) key);
            add_service_registration(typeof(TService), key_value);
            return this;
        }

        public IRegistrationContext<T> as_decorator<TService>()
            requires(typeof(T).is_a(typeof(TService)))
        {
            decorations.add(typeof(TService));
            return this;
        }

        public abstract IRegistrationContext<T> ignore_property(string property);

        private void add_service_registration(Type service, Value? key = null)
        {
            var existing_regs = services.filter(s => s.service_type == service).chop(0, 1);
            if(existing_regs.next())
            {
                var reg = existing_regs.get();
                if(key == null)
                    return;

                reg.keys.add(key);
                return;
            }

            var new_reg = (ServiceRegistration) Object.new(typeof(ServiceRegistration), service_type: service, keys: new LinkedList<Value?>());
            if(key != null)
                new_reg.keys.add(key);

            services.add(new_reg);
        }
    }

    internal class ServiceRegistration : Object
    {
        public Type service_type {get; construct set;}
        public Collection<Value?> keys {get; construct; default = new LinkedList<Value?>();}
    }
}
