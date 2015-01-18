namespace Diva
{
    [GenericAccessors]
    public interface IRegistrationContext<T> : Object
    {
        public abstract ICreator GetCreator();
        public Type Type {get {return typeof(T);}}
        public abstract IRegistrationContext<T> As<TInterface>();
    }
}
