 using Gee;

namespace Diva
{
    [GenericAccessors]
    public interface IRegistrationContext<T> : Object
    {
        public abstract ICreator GetCreator();
        public Type Type {get {return typeof(T);}}

        internal abstract Collection<Type> services {get;}
        internal abstract CreationStrategy creation_strategy {get; set;}

        public IRegistrationContext<T> As<TInterface>()
        {
            services.add(typeof(TInterface));
            return this;
        }

        public IRegistrationContext<T> SingleInstance()
        {
            creation_strategy = CreationStrategy.SingleInstance;
            return this;
        }
    }
}
