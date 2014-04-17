using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.TeamFoundation.Client;
using Microsoft.TeamFoundation.VersionControl.Client;

namespace PoshTfs.Utils
{
    public static class TfsUtils
    {
        private static List<ChangeType> AddTypes
        {
            get
            {
                return new List<ChangeType>
                           {
                               ChangeType.Add,
                               ChangeType.Merge,
                               ChangeType.Undelete
                           };
            }
        }

        private static List<ChangeType> EditTypes
        {
            get
            {
                return new List<ChangeType>
                           {
                               ChangeType.Branch,
                               ChangeType.Edit,
                               ChangeType.Encoding,
                               ChangeType.Lock,
                               ChangeType.Property,
                               ChangeType.Rename,
                               ChangeType.Rollback,
                               ChangeType.SourceRename
                           };
            }
        }

        private static List<ChangeType> DeleteTypes
        {
            get
            {
                return new List<ChangeType>
                           {
                               ChangeType.Delete
                           };
            }
        }

        public static string GetCurrentBranchName(string path)
        {
            if (!IsUnderVersionControl(path))
               return null;

            Item item = GetVersionControlServer().GetItem(
                                                      path: path,
                                                      version: VersionSpec.Latest,
                                                      deletedState: DeletedState.NonDeleted,
                                                      options: GetItemsOptions.IncludeBranchInfo
                                                  );
            if (item.IsBranch)
                return Path.GetFileName(path);
            else
                return GetCurrentBranchName(Directory.GetParent(path).FullName);
        }

        public static TfsChangeResults GetPendingChanges(string path)
        {
            Workspace workspace = GetVersionControlServer().TryGetWorkspace(path);

            if (workspace == null)
                return null;

            var changes = workspace.GetPendingChanges(path, RecursionType.Full);

            int adds = 0;
            int edits = 0;
            int deletes = 0;

            foreach (var change in changes)
            {
                if (AddTypes.Any(t => (change.ChangeType & t) == t))
                {
                    adds++;
                    continue;
                }
                else if (DeleteTypes.Any(t => (change.ChangeType & t) == t))
                {
                    deletes++;
                    continue;
                }
                else
                {
                    edits++;
                }
            }

            return new TfsChangeResults(adds, edits, deletes);
        }

        private static VersionControlServer GetVersionControlServer()
        {
            var collection = RegisteredTfsConnections.GetProjectCollections()
                                                     .Select(c => TfsTeamProjectCollectionFactory.GetTeamProjectCollection(c))
                                                     .FirstOrDefault();

            if (collection != null)
                return collection.GetService<VersionControlServer>();

            throw new Exception("Can't find registered TFS connection");
        }

        private static bool IsUnderVersionControl(string path)
        {
            return GetVersionControlServer().TryGetWorkspace(path) != null;
        }

    }
}
