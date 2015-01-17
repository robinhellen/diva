using GLib.Test;

using Diva;

namespace Ldraw.Tests
{
    static int main(string[] args)
    {
        Test.init(ref args);
        var rootSuite = TestSuite.get_root();

        rootSuite.add_suite(new SimpleTest().get_suite());

        Test.run();
        return 0;
    }

    public class SimpleTest : TestFixture
    {
        public SimpleTest()
        {
            base("SimpleTest");
            add_test("SimpleResolve", SimpleResolve);
        }

        private void SimpleResolve()
        {
            var builder = new ContainerBuilder();
            builder.Register<TestClass>(_ => new TestClass());

            var container = builder.Build();
            var testClass = container.Resolve<TestClass>();
            if(testClass == null)
                fail();
        }

        private class TestClass : Object {}
    }

    public abstract class TestFixture : Object
    {
        private GLib.TestSuite suite;
        private Adaptor[] adaptors = new Adaptor[0];

        public delegate void TestMethod ();
        public delegate void TheoryMethod<T>(T datapoint);
        public delegate string TheoryName<T>(T datapoint);

        protected TestFixture (string name)
        {
            this.suite = new GLib.TestSuite (name);
        }

        protected void add_test (string name, owned TestMethod test)
        {
            var adaptor = new Adaptor (name, (owned)test, this);
            this.adaptors += adaptor;

            this.suite.add (new GLib.TestCase (adaptor.name,
                                               adaptor.set_up,
                                               adaptor.run,
                                               adaptor.tear_down ));
        }

        public virtual void set_up () {
        }

        public virtual void tear_down () {
        }

        public GLib.TestSuite get_suite () {
            return this.suite;
        }

        private class Adaptor {

            public string name { get; private set; }
            private TestMethod test;
            private TestFixture test_case;

            public Adaptor (string name,
                            owned TestMethod test,
                            TestFixture test_case) {
                this.name = name;
                this.test = (owned)test;
                this.test_case = test_case;
            }

            public void set_up (void* fixture) {
                this.test_case.set_up ();
            }

            public void run (void* fixture) {
                this.test ();
            }

            public void tear_down (void* fixture) {
                this.test_case.tear_down ();
            }
        }
    }
}
