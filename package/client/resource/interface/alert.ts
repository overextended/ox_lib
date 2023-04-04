interface AlertDialogProps {
  header: string;
  content: string;
  centered?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  overflow?: boolean;
  cancel?: boolean;
  labels?: {
    cancel?: string;
    confirm?: string;
  };
}

type alertDialog = (data: AlertDialogProps) => Promise<'cancel' | 'confirm'>;

export const alertDialog: alertDialog = async (data) => await exports.ox_lib.alertDialog(data);

export const closeAlertDialog = () => exports.ox_lib.closeAlertDialog();
