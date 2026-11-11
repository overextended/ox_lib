import { createLocales } from "@overextended/ox_lib";

const Locale = createLocales<typeof import("../../locales/en.json")>();

export default Locale;
