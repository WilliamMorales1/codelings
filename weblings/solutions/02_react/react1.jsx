// react1.jsx -- reference solution.

export function ProfileCard({ user }) {
  return (
    <>
      <h2 className="title">{user.name}</h2>
      <img src={user.avatar} alt={`${user.name}'s avatar`} />
      <label htmlFor="bio">Bio</label>
      <textarea id="bio" defaultValue={user.bio}></textarea>
      <p style={{ color: 'gray' }}>Joined {user.joined}</p>
    </>
  );
}
