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
    public partial class LoginInfo : Form
    {
        LoginPage loginPage;
        public LoginInfo()
        {
            InitializeComponent();
        }

        Bitmap buttonLargeEventEnter = Properties.Resources.LoginButtonLargeHover;
        Bitmap buttonLargeEventLeave = Properties.Resources.LoginButtonLarge;

        private void label2_Click(object sender, EventArgs e)
        {
            if (loginPage == null)
            {
                loginPage = new LoginPage();   //Create LoginPage
                loginPage.FormClosed += loginPage_FormClosed;  //Add eventhandler to cleanup
            }

            loginPage.Show(this);  //Show Form 
            Hide();
        }

        void loginPage_FormClosed(object sender, FormClosedEventArgs e)
        {
            loginPage = null;  //If form is closed make sure reference is set to null
            Hide();
        }

        private void button1_MouseEnter(object sender, EventArgs e)
        {
            button1.Image = buttonLargeEventEnter;
        }

        private void button1_MouseLeave(object sender, EventArgs e)
        {
            button1.Image = buttonLargeEventLeave;
        }

        private void pictureBox4_Click(object sender, EventArgs e)
        {
            if (textBox2.UseSystemPasswordChar == false)
            {
                textBox2.UseSystemPasswordChar = true;
            } else if (textBox2.UseSystemPasswordChar == true)
            {
                textBox2.UseSystemPasswordChar = false;
            }
        }
    }
}
