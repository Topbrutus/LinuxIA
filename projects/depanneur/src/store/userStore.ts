import { create } from "zustand";
import { persist } from "zustand/middleware";

export type UserGender =
  | "homme"
  | "femme"
  | "autre"
  | "prefere-ne-pas-dire";

export type AvatarId = "blank-white" | "blank-black" | (string & {});

export interface UserProfile {
  name: string;
  address: string;
  gender: UserGender;
  avatarId: AvatarId;
}

interface UserStore {
  user: UserProfile | null;
  setUser: (user: UserProfile) => void;
  clearUser: () => void;
}

export const useUserStore = create<UserStore>()(
  persist(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
      clearUser: () => set({ user: null }),
    }),
    { name: "sdq_user" }
  )
);
