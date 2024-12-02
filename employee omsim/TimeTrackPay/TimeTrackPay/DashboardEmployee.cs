using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TimeTrackPay
{
    public partial class DashboardEmployee : Form
    {
        public DashboardEmployee()
        {       
            InitializeComponent();
        }

        private void DashboardEmployee_Load(object sender, EventArgs e)
        {

        }

        private void button_Click(object sender, EventArgs e)
        {
            foreach(var btn in this.Controls.OfType<button>())
                btn.BackColor = Color.FromArgb(34, 100, 102);
            button Buttons = (button)sender;
            Buttons.BackColor = Color.FromArgb(82, 85, 76);
           
        }
    }
}
