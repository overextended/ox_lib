interface AlertDialogProps {
  header: string;
  content: string;
  centered?: boolean;
  cancel?: boolean;
}

type alertDialog = (data: AlertDialogProps) => Promise<'cancel' | 'confirm'>;

export const alertDialog: alertDialog = async (data) => await exports.ox_lib.alertDialog(data);
