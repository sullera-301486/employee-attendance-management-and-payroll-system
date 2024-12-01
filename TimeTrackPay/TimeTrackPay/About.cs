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
   
    public partial class About : Form
    {
        LoginPage loginPage;
        public About()
        {
            InitializeComponent();
        }

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
    }
}
