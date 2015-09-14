using GLib.Test;

namespace Diva.Tests
{
    class RegistrationErrors : TestFixture
    {
        public RegistrationErrors()
        {
            base("Registration Errors");
            add_test("ErrorIfRegisteredAsInterfaceNotImplemented", ErrorIfRegisteredAsInterfaceNotImplemented);
            add_test("ErrorIfRegisteredAsDecoratorForInterfaceNotImplemented", ErrorIfRegisteredAsDecoratorForInterfaceNotImplemented);
            add_test("ErrorIfRegisteredKeyedForInterfaceNotImplemented", ErrorIfRegisteredKeyedForInterfaceNotImplemented);
        }

        private void ErrorIfRegisteredAsInterfaceNotImplemented()
        {
            var builder = new ContainerBuilder();
            var reg = builder.register<NoInterface>();

            assert_traps(() => reg.as<TestInterface>());
        }

        private void ErrorIfRegisteredAsDecoratorForInterfaceNotImplemented()
        {
            var builder = new ContainerBuilder();
            var reg = builder.register<NoInterface>();

            assert_traps(() => reg.as_decorator<TestInterface>());
        }

        private void ErrorIfRegisteredKeyedForInterfaceNotImplemented()
        {
            var builder = new ContainerBuilder();
            var reg = builder.register<NoInterface>();

            assert_traps(() => reg.keyed<TestInterface, string>("foo"));
        }

        private class NoInterface {}

        private void assert_traps(TrappingFunc func)
        {
            if(subprocess())
            {
                func();
                return;
            }
            trap_subprocess(null, 0, (TestSubprocessFlags) 0);
            trap_assert_failed();
        }
    }

    private delegate void TrappingFunc();
}
