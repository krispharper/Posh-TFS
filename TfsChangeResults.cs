namespace Posh_TFS.Utils
{
    public class TfsChangeResults
    {
        public int Adds
        {
            get;
            private set;
        }

        public int Edits
        {
            get;
            private set;
        }

        public int Deletes
        {
            get;
            private set;
        }

        public TfsChangeResults(int adds, int edits, int deletes)
        {
            this.Adds = adds;
            this.Deletes = deletes;
            this.Edits = edits;
        }
    }
}
