using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TimeTrackPay
{
    public partial class LoginPage : Form
    {
        About about;
        LoginInfo loginInfo;
        public LoginPage()
        {
            InitializeComponent();
        }

        Bitmap buttonEventEnter = Properties.Resources.LoginButtonHover;
        Bitmap buttonEventLeave = Properties.Resources.LoginButton;

        private void button1_MouseEnter(object sender, EventArgs e)
        {
            button1.Image = buttonEventEnter;
        }

        private void button1_MouseLeave(object sender, EventArgs e)
        {
            button1.Image= buttonEventLeave;
        }

        private void label2_Click(object sender, EventArgs e)
        {
            if (about == null)
            {
                about = new About();   //Create About
                about.FormClosed += About_FormClosed;  //Add eventhandler to cleanup
            }

            about.Show(this);  //Show Form 
            Hide();
        }

         void About_FormClosed(object sender, FormClosedEventArgs e)
        {
            about = null;  //If form is closed make sure reference is set to null
            Hide();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (loginInfo == null)
            {
                loginInfo = new LoginInfo();   //Create LoginInfo
                loginInfo.FormClosed += loginInfo_FormClosed;  //Add eventhandler to cleanup
            }

            loginInfo.Show(this);  //Show Form 
            Hide();
        }

        void loginInfo_FormClosed(object sender, FormClosedEventArgs e)
        {
            loginInfo = null;  //If form is closed make sure reference is set to null
            Hide();
        }
    }
}
