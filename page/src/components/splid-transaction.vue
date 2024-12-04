<template>
  <div class="">
    {{ id }} {{ transaction }}
    <button v-if="!isConfirmed" @click="confirmTransaction()">Confirm</button>
    <button @click="deleteTransaction()">Delete</button>
    <div class="flex gap-4">
      <div class="size-12 border rounded">
        <img v-if="transactionFile" :src="transactionFile" alt="" class="size-12" />
      </div>
      <div
        class="py-1 px-4 border border-blue-900 w-fit cursor-pointer flex items-center rounded"
        @click="openFileDialog()"
      >
        File upload
      </div>
      <div class="text-xs flex items-center">
        {{ transactionFile }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAPI } from "../composables/useAPI";
import { transactionToJson } from "../../../functions/src/models/Transaction";
import { computed, watch } from "vue";
import { user } from "../firebase/auth";
import { toDownloadURL, useFileUpload } from "../composables/useFileUpload";

const props = defineProps<{
  id: string;
  groupID: string;
  transaction: ReturnType<typeof transactionToJson>;
}>();

const isConfirmed = computed(
  () =>
    !props.transaction.friends[user.value?.uid!] ||
    props.transaction.friends[user.value?.uid!]?.isConfirmed
);

const confirmTransaction = () => {
  useAPI().confirmTransaction(props.groupID, props.id);
};

const deleteTransaction = () => {
  useAPI().deleteTransaction(props.groupID, props.id);
};

const { open: openFileDialog, downloadURL, uploadedFileName } = useFileUpload();
watch(uploadedFileName, (fileName) => {
  useAPI().addFileToTransaction(props.groupID, props.id, fileName || "");
});

const transactionFile = computed(() => {
    const url = uploadedFileName.value || props.transaction.meta.storageURL
    return url ? toDownloadURL(url) : ''
});
</script>
