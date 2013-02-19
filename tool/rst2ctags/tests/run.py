import sys
import glob
import os
import unittest
sys.path.append('../')
import rst2ctags

if sys.version_info[0] >= 3:
    from io import StringIO
else:
    from StringIO import StringIO



class TestFindFiles(unittest.TestCase):

    def setUp(self):
        self.main = set(os.path.abspath(f) for f in glob.glob("../*.rst"))
        self.test = set(os.path.abspath(f) for f in glob.glob("*.rst"))
        self.doc = set(os.path.abspath(f) for f in glob.glob("../doc/*.rst"))

    def test_recursive(self):
        self.assertEqual(self.test, rst2ctags.get_rst_files(["."], True))
        self.assertEqual(self.test, rst2ctags.get_rst_files(["data.rst"], True))
        self.assertEqual(set.union(self.test, self.main, self.doc),
                         rst2ctags.get_rst_files([".."], True))
        self.assertEqual(set.union(self.test, self.doc),
                         rst2ctags.get_rst_files(["data.rst", "../doc"], True))

    def test_non_recursive(self):
        self.assertEqual(self.test, rst2ctags.get_rst_files(["data.rst"], False))
        self.assertEqual(set([]), rst2ctags.get_rst_files(["."], False))


class TestCTagsWriter(unittest.TestCase):

    def setUp(self):
        self.writer = rst2ctags.CTagsWriter
        self.output = StringIO()

    def test_sort(self):
        pass


class TestMain(unittest.TestCase):

    def setUp(self):
        self.backup_stdout = sys.stdout
        with open('tags') as f:
            self.ref = f.read()

    def test_write_file(self):
        sys.argv = ['rst2ctags.py', 'data.rst', '-f', 'tags.out']
        rst2ctags.main()
        with open('tags.out') as f:
            out = f.read()
        self.assertEqual(self.ref, out)

    def test_write_stdout(self):
        backup = sys.stdout
        output = StringIO()
        sys.stdout = output
        sys.argv = ['rst2ctags.py', 'data.rst', '-f', '-']
        rst2ctags.main()
        self.assertTrue(self.ref.endswith(output.getvalue()))
        sys.stdout = backup


    def tearDown(self):
        sys.stdout = self.backup_stdout
        if os.path.exists('tags.out'):
            os.unlink('tags.out')

if __name__ == '__main__':
    unittest.main()

