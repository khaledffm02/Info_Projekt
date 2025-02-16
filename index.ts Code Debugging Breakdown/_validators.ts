export const validateRequestParams = (params: Record<string, any>, requiredParams: string[]) => {
    for (const param of requiredParams) {
      if (!params[param]) {
        return { success: false, message: `Missing parameter: ${param}` };
      }
    }
    return { success: true };
  };
  