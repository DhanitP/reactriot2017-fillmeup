import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { Link } from 'react-router';

export const NavDropdown = ({ userDetail, signOut }) =>
  (
    <ul className="nav navbar-nav navbar-right">
      {
        userDetail ?
        (
          <li className="dropdown user-info">
            <a href="#" className="dropdown-toggle" data-toggle="dropdown">
              <div><i className="fa fa-user-circle" /> {userDetail.email}</div>
            </a>
            <ul className="dropdown-menu">
              <li><Link to="/pumps/new">Add Station</Link></li>
              <li onClick={() => signOut()}><Link to="/">Sign Out</Link></li>
            </ul>
          </li>
        ) :
        (
          <li className="user-info">
            <Link to="/login">Sign In</Link>
          </li>
        )
      }
    </ul>
  );

export default connect()(NavDropdown);

NavDropdown.defaultProps = {
  userDetail: null,
};
