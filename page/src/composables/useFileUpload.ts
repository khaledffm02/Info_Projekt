import { useFileDialog } from "@vueuse/core";
import { storage } from "../firebase/storage";
import { ref as storageRef, uploadBytes } from "firebase/storage";
import { ref } from "vue";

const UPLOAD_PATH = "images";
export const toDownloadURL = (fileName: string) =>
  `https://storage.googleapis.com/projekt-24-a9104.firebasestorage.app/images/${fileName}`;

export const useFileUpload = () => {
  const { files, open, reset, onCancel, onChange } = useFileDialog({
    accept: "image/*", // Set to accept only image files
    multiple: false,
  });

  const downloadURL = ref("");
  const uploadedFileName = ref("");

  onChange(async (files) => {
    const file = files?.[0];
    if (!file) return;

    const { name } = file;
    const {
      groups: { extension },
    } = name.match(/^.+[.](?<extension>.{2,4})$/v) ?? ({ groups: {} } as any);
    if (!extension) return;

    const fileName = Math.random().toString(36).substring(2) + "." + extension;
    const storageFileReference = storageRef(
      storage,
      `${UPLOAD_PATH}/${fileName}`
    );

    await uploadBytes(storageFileReference, file);

    downloadURL.value = toDownloadURL(fileName);
    uploadedFileName.value = fileName;
  });

  onCancel(() => {
    /** do something on cancel */
  });

  return { open, downloadURL, uploadedFileName };
};
