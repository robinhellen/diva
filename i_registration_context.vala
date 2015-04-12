 using Gee;

namespace Diva
{
    [GenericAccessors]
    public interface IRegistrationContext<T> : Object
    {
        public abstract ICreator GetCreator();
        public Type Type {get {return typeof(T);}}

        internal abstract Collection<ServiceRegistration> services {get;}
        internal abstract CreationStrategy creation_strategy {get; set;}

        public IRegistrationContext<T> As<TInterface>()
        {
            AddServiceRegistration(typeof(TInterface));
            return this;
        }

        public IRegistrationContext<T> SingleInstance()
        {
            creation_strategy = CreationStrategy.SingleInstance;
            return this;
        }
        
        public IRegistrationContext<T> Keyed<TService, TKey>(TKey key)
        {
			var t = typeof(TKey);
			var keyValue = Value(t);
			if(t.is_object())
				keyValue.set_object((Object)key);
			if(t.is_enum())
				keyValue.set_enum((int) key);
            AddServiceRegistration(typeof(TService), keyValue);
            return this;
        }
        
        public abstract IRegistrationContext<T> IgnoreProperty(string property);
        
        private void AddServiceRegistration(Type service, Value? key = null)
        {
            var existingRegs = services.filter(s => s.ServiceType == service).chop(0, 1);
            if(existingRegs.next())
            {
                var reg = existingRegs.get();
                if(key == null)
                    return;
                
                reg.Keys.add(key);
                return;
            }
            
            var newReg = (ServiceRegistration) Object.new(typeof(ServiceRegistration), ServiceType: service, Keys: new LinkedList<Value?>());
            if(key != null)
                newReg.Keys.add(key);
            
            services.add(newReg);
        }
    }
    
    internal class ServiceRegistration : Object
    {
        public Type ServiceType {get; construct set;}
        public Collection<Value?> Keys {get; construct; default = new LinkedList<Value?>();}
    }
}
