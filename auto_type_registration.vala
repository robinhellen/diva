namespace Diva
{
    internal class AutoTypeRegistration<T> : Object, IRegistrationContext<T>
    {
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
            {
                return (T) Object.new(typeof(T));
            }
        }
    }
}
