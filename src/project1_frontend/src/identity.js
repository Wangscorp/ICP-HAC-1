
// src/identity.js
import { AuthClient } from '@dfinity/auth-client';

export const initIdentity = async () => {
  const authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    return authClient;
  } else {
    await authClient.login({
      identityProvider: 'https://identity.ic0.app',
      onSuccess: () => {
        window.location.reload();
      },
    });
  }
};
