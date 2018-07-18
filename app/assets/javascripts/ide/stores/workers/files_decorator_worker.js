import { viewerInformationForPath } from '~/vue_shared/components/content_viewer/lib/viewer_utils';
import { decorateData, sortTree } from '../utils';

// eslint-disable-next-line no-restricted-globals
self.addEventListener('message', e => {
  const { data, projectId, branchId, tempFile = false, content = '', base64 = false } = e.data;

  const treeList = [];
  let file;
  let parentPath;
  const entries = data.reduce((acc, path) => {
    const pathSplit = path.split('/');
    const blobName = pathSplit.pop().trim();

    if (pathSplit.length > 0) {
      pathSplit.reduce((pathAcc, folderName) => {
        const parentFolder = acc[pathAcc[pathAcc.length - 1]];
        const folderPath = `${parentFolder ? `${parentFolder.path}/` : ''}${folderName}`;
        const foundEntry = acc[folderPath];

        if (!foundEntry) {
          parentPath = parentFolder ? parentFolder.path : null;

          const tree = decorateData({
            projectId,
            branchId,
            id: folderPath,
            name: folderName,
            path: folderPath,
            url: `/${projectId}/tree/${branchId}/-/${folderPath}/`,
            type: 'tree',
            parentTreeUrl: parentFolder ? parentFolder.url : `/${projectId}/tree/${branchId}/`,
            tempFile,
            changed: tempFile,
            opened: tempFile,
            parentPath,
          });

          Object.assign(acc, {
            [folderPath]: tree,
          });

          if (parentFolder) {
            parentFolder.tree.push(tree);
          } else {
            treeList.push(tree);
          }

          pathAcc.push(tree.path);
        } else {
          pathAcc.push(foundEntry.path);
        }

        return pathAcc;
      }, []);
    }

    if (blobName !== '') {
      const fileFolder = acc[pathSplit.join('/')];
      parentPath = fileFolder ? fileFolder.path : null;

      file = decorateData({
        projectId,
        branchId,
        id: path,
        name: blobName,
        path,
        url: `/${projectId}/blob/${branchId}/-/${path}`,
        type: 'blob',
        parentTreeUrl: fileFolder ? fileFolder.url : `/${projectId}/blob/${branchId}`,
        tempFile,
        changed: tempFile,
        content,
        base64,
        previewMode: viewerInformationForPath(blobName),
        parentPath,
      });

      Object.assign(acc, {
        [path]: file,
      });

      if (fileFolder) {
        fileFolder.tree.push(file);
      } else {
        treeList.push(file);
      }
    }

    return acc;
  }, {});

  // eslint-disable-next-line no-restricted-globals
  self.postMessage({
    entries,
    treeList: sortTree(treeList),
    file,
    parentPath,
  });
});
