import org.sonatype.nexus.blobstore.api.BlobStoreManager; 
import org.sonatype.nexus.repository.storage.WritePolicy; 

repository.createDockerHosted('expleo', 5000, 443, BlobStoreManager.DEFAULT_BLOBSTORE_NAME, true, true, WritePolicy.ALLOW)