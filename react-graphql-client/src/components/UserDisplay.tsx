import * as React  from 'react';
import { Query } from 'react-apollo';
import gql from 'graphql-tag';

const USERS_QUERY = gql`
    {
        users {
            id
            email
        }
    }
`;

const UserDisplay = () => {
  return (
    <div>
      <Query query={USERS_QUERY}>
        {({ loading, error, data }) => {
          if (loading) return <div>Fetching</div>;
          if (error) return <div>Error</div>;

          // @ts-ignore
          const users: User[] = data.users;

          return (
            <div>
              {users.map((user, i) => (
                <div key={i}>
                  <p>{user.id}</p>
                  <p>{user.email}</p>
                </div>
              ))}
            </div>
          );
        }}
      </Query>
    </div>
  );
};

export default UserDisplay;